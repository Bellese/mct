import { Box } from '@mui/material';
import { useSelector } from 'react-redux';
import Navigation from './Navigation';
import SimpleBar from 'components/third-party/SimpleBar';
import FacilitiesSingleSelect from 'components/FacilitiesSingleSelect';

const DrawerContent = () => {
  const { facilities } = useSelector((state) => state.data);

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <SimpleBar
        sx={{
          flexGrow: 1,
          '& .simplebar-content': {
            display: 'flex',
            flexDirection: 'column'
          }
        }}
      >
        <Navigation />
      </SimpleBar>
      <Box sx={{ px: 3, pb: 3 }}>
        <FacilitiesSingleSelect facilities={facilities} />
      </Box>
    </Box>
  );
};

export default DrawerContent;
