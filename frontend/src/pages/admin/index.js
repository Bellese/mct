import { Box, Card, CardContent, Divider, Typography } from '@mui/material';
import { ArrowRightOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { activeItem } from 'store/reducers/filter';

const settingsItems = [
  {
    id: 'clinical-data-sources',
    title: 'Clinical Data Sources',
    description: 'Connect and manage external clinical data repositories used by the tool.',
    path: '/admin/clinical-data-sources'
  }
];

const AdminPage = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch();

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, p: 3 }}>
      <Typography
        component="button"
        onClick={() => {
          dispatch(activeItem({ openItem: ['dashboard'] }));
          navigate('/dashboard/default');
        }}
        sx={{
          alignSelf: 'flex-start',
          background: 'none',
          border: 'none',
          color: 'primary.main',
          cursor: 'pointer',
          fontSize: '1rem',
          fontWeight: 600,
          p: 0,
          '&:hover': { textDecoration: 'underline' }
        }}
      >
        ← Home
      </Typography>

      <Typography variant="h1" sx={{ fontSize: '2.625rem' }}>
        Settings
      </Typography>

      <Card
        elevation={0}
        sx={{
          border: '1px solid',
          borderColor: 'grey.200',
          borderRadius: 3
        }}
      >
        <CardContent sx={{ p: 3, '&:last-child': { pb: 3 } }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            {settingsItems.map((item, index) => (
              <Box key={item.id}>
                <Box
                  onClick={() => navigate(item.path)}
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    cursor: 'pointer',
                    '&:hover .settings-arrow': { transform: 'translateX(4px)' }
                  }}
                >
                  <Box>
                    <Typography variant="h5" sx={{ color: 'primary.main', fontSize: '1.125rem' }}>
                      {item.title}
                    </Typography>
                    <Typography variant="body1" sx={{ fontSize: '1rem' }}>
                      {item.description}
                    </Typography>
                  </Box>
                  <Box sx={{ color: 'primary.main', flexShrink: 0, ml: 2 }}>
                    <ArrowRightOutlined
                      className="settings-arrow"
                      style={{
                        fontSize: '2rem',
                        color: 'currentColor',
                        transition: 'transform 0.2s ease'
                      }}
                    />
                  </Box>
                </Box>
                {index < settingsItems.length - 1 && <Divider sx={{ mt: 2 }} />}
              </Box>
            ))}
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
};

export default AdminPage;
