import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import { useDispatch, useSelector } from 'react-redux';
import { inputSelection } from 'store/reducers/filter';
import { fetchFacilityPatients } from 'store/reducers/data';

const FacilitiesSingleSelect = ({ facilities }) => {
  const dispatch = useDispatch();
  const { selectedFacilities } = useSelector((state) => state.filter);
  const selectedFacility = selectedFacilities?.[0] || '';

  const handleChange = (event) => {
    const value = event.target.value;
    dispatch(inputSelection({ type: 'selectedFacilities', value: [value] }));
    dispatch(inputSelection({ type: 'selectedPatients', value: [] }));
    dispatch(fetchFacilityPatients());
  };

  const facilityEntries = facilities
    ?.map((i) => ({ id: i.id, name: i.name }))
    .filter((facility, index, self) => self.findIndex((f) => f.id === facility.id) === index);

  return (
    <FormControl required variant="standard" fullWidth>
      <InputLabel id="facility-select-label">Clinical Data Source</InputLabel>
      <Select labelId="facility-select-label" id="facility-select" value={selectedFacility} onChange={handleChange}>
        {facilityEntries?.map(({ id, name }, index) => (
          <MenuItem key={id + '_' + index} value={id}>
            {name}
          </MenuItem>
        ))}
      </Select>
    </FormControl>
  );
};

export default FacilitiesSingleSelect;
