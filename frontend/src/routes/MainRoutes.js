import { lazy } from 'react';

// project import
import Loadable from 'components/Loadable';
import MainLayout from 'layout/MainLayout';

// render - dashboard
const DashboardDefault = Loadable(lazy(() => import('pages/dashboard')));
const AdminPage = Loadable(lazy(() => import('pages/admin')));
const ClinicalDataSources = Loadable(lazy(() => import('pages/admin/ClinicalDataSources')));

const MainRoutes = {
  path: '/',
  element: <MainLayout />,
  children: [
    {
      path: '/',
      element: <DashboardDefault />
    },
    {
      path: 'dashboard',
      children: [
        {
          path: 'default',
          element: <DashboardDefault />
        }
      ]
    },
    {
      path: 'admin',
      element: <AdminPage />
    },
    {
      path: 'admin/clinical-data-sources',
      element: <ClinicalDataSources />
    }
  ]
};

export default MainRoutes;
