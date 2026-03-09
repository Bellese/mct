import { DashboardOutlined, SettingOutlined } from '@ant-design/icons';

const icons = {
  DashboardOutlined,
  SettingOutlined
};

const dashboard = {
  id: 'group-dashboard',
  title: 'Navigation',
  type: 'group',
  children: [
    {
      id: 'dashboard',
      title: 'Dashboard',
      type: 'item',
      url: '/dashboard/default',
      icon: icons.DashboardOutlined,
      breadcrumbs: false
    },
    {
      id: 'admin',
      title: 'Admin',
      type: 'item',
      url: '/admin',
      icon: icons.SettingOutlined,
      breadcrumbs: false
    }
  ]
};

export default dashboard;
