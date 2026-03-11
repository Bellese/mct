import { useState } from 'react';
import { Box, Button, Card, CardContent, Divider, Snackbar, Typography } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { addFacility, updateFacility, removeFacility } from 'store/reducers/data';
import { activeItem } from 'store/reducers/filter';
import DataSourceFormDialog from './DataSourceFormDialog';
import RemoveDataSourceDialog from './RemoveDataSourceDialog';

const ClinicalDataSources = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const facilities = useSelector((state) => state.data.facilities);
  const sources = facilities.map((f) => ({ id: f.id, name: f.name, url: f.contained?.[0]?.address || '' }));

  const [dialogOpen, setDialogOpen] = useState(false);
  const [removeDialogOpen, setRemoveDialogOpen] = useState(false);
  const [formValues, setFormValues] = useState({ name: '', url: '' });
  const [editingSource, setEditingSource] = useState(null);
  const [sourceToRemove, setSourceToRemove] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  const showSnackbar = (message, severity = 'success') => setSnackbar({ open: true, message, severity });
  const closeSnackbar = () => setSnackbar((prev) => ({ ...prev, open: false }));

  const openAddDialog = () => {
    setEditingSource(null);
    setFormValues({ name: '', url: '' });
    setDialogOpen(true);
  };

  const openEditDialog = (source) => {
    setEditingSource(source);
    setFormValues({ name: source.name, url: source.url });
    setDialogOpen(true);
  };

  const handleSave = async () => {
    try {
      if (editingSource) {
        await dispatch(updateFacility({ id: editingSource.id, ...formValues })).unwrap();
        showSnackbar('Clinical data source updated successfully.');
      } else {
        await dispatch(addFacility(formValues)).unwrap();
        showSnackbar('Clinical data source added successfully.');
      }
      setDialogOpen(false);
    } catch (e) {
      showSnackbar(e.message || 'Failed to save clinical data source.', 'error');
    }
  };

  const openRemoveDialog = (source) => {
    setSourceToRemove(source);
    setRemoveDialogOpen(true);
  };

  const confirmRemove = async () => {
    try {
      await dispatch(removeFacility(sourceToRemove.id)).unwrap();
      setRemoveDialogOpen(false);
      setSourceToRemove(null);
      showSnackbar('Clinical data source removed successfully.');
    } catch (e) {
      showSnackbar(e.message || 'Failed to remove clinical data source.', 'error');
    }
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, p: 3 }}>
      <Typography
        component="button"
        onClick={() => {
          dispatch(activeItem({ openItem: ['admin'] }));
          navigate('/admin');
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
        ← Settings
      </Typography>

      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 2 }}>
        <Box>
          <Typography variant="h1" sx={{ fontSize: '2.625rem' }}>
            Clinical Data Sources
          </Typography>
          <Typography variant="body1">Connect and manage external clinical data repositories used by the tool.</Typography>
        </Box>
        <Button variant="contained" onClick={openAddDialog} sx={{ flexShrink: 0 }}>
          Add Data Source
        </Button>
      </Box>

      <Card elevation={0} sx={{ border: '1px solid', borderColor: 'grey.200', borderRadius: 3 }}>
        <CardContent sx={{ p: 3, '&:last-child': { pb: 3 } }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            {sources.map((source, index) => (
              <Box key={source.id}>
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                  <Typography sx={{ fontSize: '1.125rem', fontWeight: 700, color: '#1e1e1e' }}>{source.name}</Typography>
                  <Typography sx={{ fontSize: '1rem', color: '#1e1e1e' }}>
                    <Box component="span" sx={{ fontWeight: 700 }}>
                      URL:{' '}
                    </Box>
                    {source.url}
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 2 }}>
                    <Typography
                      component="button"
                      onClick={() => openEditDialog(source)}
                      sx={{
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
                      Edit
                    </Typography>
                    <Typography
                      component="button"
                      onClick={() => openRemoveDialog(source)}
                      sx={{
                        background: 'none',
                        border: 'none',
                        color: 'error.main',
                        cursor: 'pointer',
                        fontSize: '1rem',
                        fontWeight: 600,
                        p: 0,
                        '&:hover': { textDecoration: 'underline' }
                      }}
                    >
                      Remove
                    </Typography>
                  </Box>
                </Box>
                {index < sources.length - 1 && <Divider sx={{ mt: 2 }} />}
              </Box>
            ))}
            {sources.length === 0 && (
              <Typography variant="body1" sx={{ color: 'text.secondary' }}>
                No data sources configured. Click "Add Data Source" to get started.
              </Typography>
            )}
          </Box>
        </CardContent>
      </Card>

      <DataSourceFormDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        onSave={handleSave}
        editingSource={editingSource}
        formValues={formValues}
        onChange={setFormValues}
      />

      <RemoveDataSourceDialog
        open={removeDialogOpen}
        onClose={() => {
          setRemoveDialogOpen(false);
          setSourceToRemove(null);
        }}
        onConfirm={confirmRemove}
        source={sourceToRemove}
      />

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={closeSnackbar}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
      >
        <Box
          sx={{
            display: 'flex',
            alignItems: 'flex-start',
            gap: 2,
            px: 3,
            py: 2,
            bgcolor: snackbar.severity === 'error' ? '#FDECEA' : '#E7F3E7',
            borderLeft: `8px solid ${snackbar.severity === 'error' ? '#C62828' : '#12890E'}`,
            borderRadius: 1,
            minWidth: 300,
            maxWidth: 500,
            boxShadow: 3
          }}
        >
          {snackbar.severity === 'error' ? (
            <ErrorIcon sx={{ color: '#212121', fontSize: 26, flexShrink: 0 }} />
          ) : (
            <CheckCircleIcon sx={{ color: '#212121', fontSize: 26, flexShrink: 0 }} />
          )}
          <Typography sx={{ fontWeight: 600, fontSize: '1.125rem', color: '#212121', lineHeight: '23.4px' }}>
            {snackbar.message}
          </Typography>
        </Box>
      </Snackbar>
    </Box>
  );
};

export default ClinicalDataSources;
