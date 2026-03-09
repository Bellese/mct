export const getFacility = (state) => {
  const { facilities } = state.data;
  const { selectedFacilities } = state.filter;
  return facilities.filter((facility) => selectedFacilities.includes(facility.id));
};

export const getMeasure = (state) => {
  const { measures } = state.data;
  const { measure } = state.filter;

  return measures.find((i) => i.id === measure);
};

