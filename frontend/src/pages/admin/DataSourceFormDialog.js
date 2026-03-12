import { Box, Button, Dialog, DialogContent, TextField, Typography } from '@mui/material';
import { cancelBtnSx, dialogPaperSx } from './dialogStyles';

const DataSourceFormDialog = ({ open, onClose, onSave, editingSource, formValues, onChange }) => (
  <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth PaperProps={{ sx: dialogPaperSx }}>
    <DialogContent sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <Typography sx={{ fontSize: '2.125rem', fontWeight: 600, color: '#262626', lineHeight: 1.5 }}>
          {editingSource ? 'Edit Data Source Configuration' : 'Add Data Source Configuration'}
        </Typography>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          <TextField
            label="Repository Name *"
            variant="standard"
            value={formValues.name}
            onChange={(e) => onChange({ ...formValues, name: e.target.value })}
            fullWidth
            InputLabelProps={{ sx: { color: '#595959' } }}
          />
          <TextField
            label="Repository URL *"
            variant="standard"
            value={formValues.url}
            onChange={(e) => onChange({ ...formValues, url: e.target.value })}
            fullWidth
            InputLabelProps={{ sx: { color: '#595959' } }}
          />
        </Box>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mt: 1 }}>
          <Button variant="contained" onClick={onSave} disabled={!formValues.name || !formValues.url}>
            {editingSource ? 'Save' : 'Add'}
          </Button>
          <Button onClick={onClose} sx={cancelBtnSx}>
            Cancel
          </Button>
        </Box>
      </Box>
    </DialogContent>
  </Dialog>
);

export default DataSourceFormDialog;
