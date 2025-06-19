import React from "react";
import {
  Route,
  Routes,
  BrowserRouter as Router,
} from "react-router-dom";

// Import views: unique and shared
import GV_TopNav from '@/components/views/GV_TopNav.tsx';
import GV_Footer from '@/components/views/GV_Footer.tsx';
import GV_Overlay from '@/components/views/GV_Overlay.tsx';

import UV_Landing from '@/components/views/UV_Landing.tsx';
import UV_Login from '@/components/views/UV_Login.tsx';
import UV_SignUp from '@/components/views/UV_SignUp.tsx';
import UV_Dashboard from '@/components/views/UV_Dashboard.tsx';
import UV_WorkspaceOverview from '@/components/views/UV_Workspace Overview.tsx';
import UV_TaskList from '@/components/views/UV_Task List.tsx';
import UV_TaskDetails from '@/components/views/UV_Task Details.tsx';
import UV_TaskCreationEditModal from '@/components/views/UV_Task Creation/Edit Modal.tsx';
import UV_WorkspaceSettings from '@/components/views/UV_Workspace Settings & User Management.tsx';
import UV_SearchResults from '@/components/views/UV_Search Results.tsx';
import UV_Settings from '@/components/views/UV_Settings.tsx';
import UV_NotificationsSettings from '@/components/views/UV_Notifications Settings.tsx';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

// Optional: import { Provider } from 'react-redux';
// import store from './reduxStore'; // assuming redux store setup

const queryClient = new QueryClient();

// Optional: Wrap in Redux Provider if needed
// const AppWithProviders = () => (
//   <Provider store={store}>
//     <App />
//   </Provider>
// );

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  componentDidCatch(error, info) {
    // Log error if needed
    console.error(error, info);
  }
  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return this.props.children;
  }
}

const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        {/* Optional: Wrap with Redux Provider if using Redux */}
        {/* <Provider store={store}> */}
        <ErrorBoundary>
          {/* Persistent Top Navigation */}
          <div className="min-h-screen flex flex-col relative" role="application">
            <GV_TopNav />

            {/* Overlay for modals/dialogs */}
            <GV_Overlay />

            {/* Main content area: routes */}
            <div className="flex-1 container mx-auto px-4 py-4">
              <Routes>
                {/* Unique views routes */}
                <Route path="/" element={<UV_Landing />} />
                <Route path="/login" element={<UV_Login />} />
                <Route path="/signup" element={<UV_SignUp />} />
                <Route path="/dashboard" element={<UV_Dashboard />} />
                <Route path="/workspace-overview" element={<UV_WorkspaceOverview />} />
                <Route path="/tasks" element={<UV_TaskList />} />
                <Route path="/task/:taskId" element={<UV_TaskDetails />} />
                <Route path="/task/new" element={<UV_TaskCreationEditModal />} />
                <Route path="/workspace-settings" element={<UV_WorkspaceSettings />} />
                <Route path="/search" element={<UV_SearchResults />} />
                <Route path="/settings" element={<UV_Settings />} />
                <Route path="/notifications" element={<UV_NotificationsSettings />} />
                {/* Additional routes can be added here */}
              </Routes>
            </div>

            {/* Persistent Footer */}
            <GV_Footer />
          </div>
        </ErrorBoundary>
        {/* </Provider> */}
      </Router>
    </QueryClientProvider>
  );
};

export default App;