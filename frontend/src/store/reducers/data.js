import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { inputSelection } from './filter';
import { baseUrl } from 'config';
import { createPeriodFromQuarter, timeout } from 'utils/queryHelper';

const initialState = {
  facilities: [],
  patients: [],
  organizations: [],
  measures: [],

  measureReport: null,
  status: 'idle',
  error: null
};

export const fetchOrganizations = createAsyncThunk('data/fetchOrganizations', async () => {
  const organizationBundle = await fetch(`${baseUrl}/mct/$list-organizations`).then((res) => res.json());
  return organizationBundle.entry.map((i) => i.resource);
});

export const fetchFacilities = createAsyncThunk('data/fetchFacilities', async (_, { dispatch }) => {
  const facilityBundle = await fetch(`${baseUrl}/mct/$list-facilities`).then((res) => res.json());
  const mappedFacilities = facilityBundle.entry.map((i) => i.resource);
  const firstFacility = mappedFacilities?.[0]?.id;
  dispatch(inputSelection({ type: 'selectedFacilities', value: [firstFacility] }));
  dispatch(fetchFacilityPatients());
  return mappedFacilities;
});

export const fetchMeasures = createAsyncThunk('data/fetchMeasures', async (facilityId) => {
  const measureBundle = await fetch(`${baseUrl}/mct/$list-measures`).then((res) => res.json());
  return measureBundle.entry.map((i) => i.resource);
});

export const fetchPatients = createAsyncThunk('data/fetchPatients', async (organizationId) => {
  const patientGroup = await fetch(`${baseUrl}/mct/$list-org-patients?organizationId=${organizationId}`).then((res) => res.json());
  return patientGroup;
});

export const fetchFacilityPatients = createAsyncThunk('data/fetchFacilityPatients', async (_, { getState }) => {
  const {
    filter: { selectedFacilities }
  } = getState();
  if (!selectedFacilities?.length) return [];
  const facilityParams = selectedFacilities.map((i) => `facilityIds=${i}`).join('&');
  const patientGroup = await fetch(`${baseUrl}/mct/$list-facility-patients?${facilityParams}`).then((res) => res.json());
  return patientGroup;
});

const TIMEOUT_THRESHOLD = 60 * 1000 * 3; // 3 minutes
export const executeGatherOperation = createAsyncThunk('data/gatherOperation', async (_, { getState }) => {
  const {
    filter: { selectedPatients, selectedFacilities, measure, date }
  } = getState();
  const parametersPayload = buildMeasurePayload(selectedFacilities, measure, date, selectedPatients);

  const measureReportJson = await timeout(TIMEOUT_THRESHOLD, fetch(`${baseUrl}/mct/$gather`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(parametersPayload)
  })).then(function(response) {
    return response?.json();
  }).catch(function(error) {
    console.error(error)
    // might be a timeout error
    return null
  })
  
  return measureReportJson;
});

const buildLocationResource = ({ id, name, url }) => {
  const locationId = id || name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
  const endpointId = `${locationId}-endpoint`;
  return {
    resourceType: 'Location',
    id: locationId,
    name,
    status: 'active',
    mode: 'instance',
    contained: [
      {
        resourceType: 'Endpoint',
        id: endpointId,
        status: 'active',
        connectionType: {
          system: 'http://terminology.hl7.org/CodeSystem/endpoint-connection-type',
          code: 'hl7-fhir-rest'
        },
        payloadType: [{ coding: [{ system: 'http://terminology.hl7.org/CodeSystem/endpoint-payload-type', code: 'any' }] }],
        payloadMimeType: ['application/fhir+json'],
        address: url
      }
    ],
    endpoint: [{ reference: `#${endpointId}` }]
  };
};

const extractErrorMessage = async (res, fallback) => {
  try {
    const body = await res.json();
    return body?.issue?.[0]?.diagnostics || fallback;
  } catch {
    return fallback;
  }
};

export const addFacility = createAsyncThunk('data/addFacility', async (facilityData) => {
  const location = buildLocationResource(facilityData);
  const res = await fetch(`${baseUrl}/mct/$register-facility`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ resourceType: 'Parameters', parameter: [{ name: 'facility', resource: location }] })
  });
  if (!res.ok) throw new Error(await extractErrorMessage(res, 'Failed to add facility'));
  return location;
});

export const updateFacility = createAsyncThunk('data/updateFacility', async (facilityData) => {
  const location = buildLocationResource(facilityData);
  const res = await fetch(`${baseUrl}/mct/$update-facility`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ resourceType: 'Parameters', parameter: [{ name: 'facility', resource: location }] })
  });
  if (!res.ok) throw new Error(await extractErrorMessage(res, 'Failed to update facility'));
  return location;
});

export const removeFacility = createAsyncThunk('data/removeFacility', async (facilityId) => {
  const res = await fetch(`${baseUrl}/mct/$delete-facility`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ resourceType: 'Parameters', parameter: [{ name: 'facilityId', valueString: facilityId }] })
  });
  if (!res.ok) throw new Error(await extractErrorMessage(res, 'Failed to remove facility'));
  return facilityId;
});

const buildMeasurePayload = (facilityIds, measureId, quarter, patients) => {
  const period = createPeriodFromQuarter(quarter);
  const groupPatientResource = {
    resourceType: 'Group',
    member: patients.map((i) => ({ entity: { reference: i } }))
  };
  const parameterLocations = facilityIds.map((id) => ({ name: 'facilities', valueString: `Location/${id}` }));
  return {
    resourceType: 'Parameters',
    parameter: [
      ...parameterLocations,
      {
        name: 'period',
        valuePeriod: period
      },
      {
        name: 'measure',
        valueString: measureId
      },
      {
        name: 'patients',
        resource: groupPatientResource
      }
    ]
  };
};

const data = createSlice({
  name: 'data',
  initialState,
  reducers: {},
  extraReducers(builder) {
    builder
      .addCase(fetchFacilities.pending, (state, action) => {
        state.status = 'loading';
      })
      .addCase(fetchFacilities.fulfilled, (state, action) => {
        state.status = 'finalized';
        state.facilities = action.payload;
      })
      .addCase(fetchFacilities.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });

    builder
      .addCase(fetchPatients.pending, (state, action) => {
        state.status = 'loading';
      })
      .addCase(fetchPatients.fulfilled, (state, action) => {
        state.status = 'finalized';
        state.patients = action.payload;
      })
      .addCase(fetchPatients.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });

    builder
      .addCase(fetchOrganizations.pending, (state, action) => {
        state.organizations = [];
        state.status = 'loading';
      })
      .addCase(fetchOrganizations.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.organizations = action.payload;
      })
      .addCase(fetchOrganizations.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });

    builder
      .addCase(fetchMeasures.pending, (state, action) => {
        state.measures = [];
        state.status = 'loading';
      })
      .addCase(fetchMeasures.fulfilled, (state, action) => {
        state.status = 'finalized';
        state.measures = action.payload;
      })
      .addCase(fetchMeasures.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });

    builder
      .addCase(fetchFacilityPatients.pending, (state, action) => {
        state.patients = [];
        state.status = 'loading';
      })
      .addCase(fetchFacilityPatients.fulfilled, (state, action) => {
        state.status = 'finalized';
        state.patients = action.payload;
      })
      .addCase(fetchFacilityPatients.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });

    builder
      .addCase(executeGatherOperation.pending, (state, action) => {
        state.measureReport = 'pending';
      })
      .addCase(executeGatherOperation.fulfilled, (state, action) => {
        state.measureReport = action.payload;
      });

    builder
      .addCase(addFacility.fulfilled, (state, action) => {
        state.facilities = [...state.facilities, action.payload];
      });

    builder
      .addCase(updateFacility.fulfilled, (state, action) => {
        state.facilities = state.facilities.map((f) => f.id === action.payload.id ? action.payload : f);
      });

    builder
      .addCase(removeFacility.fulfilled, (state, action) => {
        state.facilities = state.facilities.filter((f) => f.id !== action.payload);
      });
  }
});

export default data.reducer;

export const {} = data.actions;
