// project import
import Navigation from './Navigation';
import SimpleBar from 'components/third-party/SimpleBar';

const DrawerContent = () => {
  return (
    <SimpleBar
      sx={{
        '& .simplebar-content': {
          display: 'flex',
          flexDirection: 'column'
        }
      }}
    >
      <Navigation />
    </SimpleBar>
  );
};

export default DrawerContent;
