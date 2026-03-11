import { Box, Button, Dialog, DialogContent, Typography } from '@mui/material';
import { cancelBtnSx, dialogPaperSx } from './dialogStyles';

const RemoveDataSourceDialog = ({ open, onClose, onConfirm, source }) => (
  <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth PaperProps={{ sx: dialogPaperSx }}>
    <DialogContent sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <Typography sx={{ fontSize: '2.125rem', fontWeight: 600, color: '#262626', lineHeight: 1.5 }}>
          Remove Data Source Configuration
        </Typography>
        <Typography sx={{ fontSize: '1.125rem', fontWeight: 700, color: '#1e1e1e' }}>
          Are you sure you want to remove this data source configuration?
        </Typography>
        {source && (
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <Typography sx={{ fontSize: '1.125rem', fontWeight: 700, color: '#1e1e1e' }}>
              {source.name}
            </Typography>
            <Typography sx={{ fontSize: '1rem', color: '#1e1e1e' }}>
              <Box component="span" sx={{ fontWeight: 700 }}>URL: </Box>
              {source.url}
            </Typography>
          </Box>
        )}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Button variant="contained" color="error" onClick={onConfirm}>
            Remove
          </Button>
          <Button onClick={onClose} sx={cancelBtnSx}>
            Cancel
          </Button>
        </Box>
      </Box>
    </DialogContent>
  </Dialog>
);

export default RemoveDataSourceDialog;
