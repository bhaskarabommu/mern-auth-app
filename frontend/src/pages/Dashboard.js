import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import DataForm from '../components/DataForm';
import DataList from '../components/DataList';
import axios from 'axios';

const Dashboard = () => {
  const { user, logout } = useAuth();
  const [dataItems, setDataItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [editingItem, setEditingItem] = useState(null);

  useEffect(() => {
    fetchDataItems();
  }, []);

  const fetchDataItems = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/data');
      setDataItems(response.data);
    } catch (error) {
      console.error('Fetch data items error:', error);
      setError('Failed to load data items');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateItem = async (itemData) => {
    try {
      const response = await axios.post('/api/data', itemData);
      setDataItems((prev) => [response.data, ...prev]);
      setShowForm(false);
      showToast('Item created successfully', 'success');
    } catch (error) {
      console.error('Create item error:', error);
      showToast('Failed to create item', 'error');
    }
  };

  const handleUpdateItem = async (id, itemData) => {
    try {
      const response = await axios.put(`/api/data/${id}`, itemData);
      setDataItems((prev) =>
        prev.map((item) => (item._id === id ? response.data : item))
      );
      setEditingItem(null);
      showToast('Item updated successfully', 'success');
    } catch (error) {
      console.error('Update item error:', error);
      showToast('Failed to update item', 'error');
    }
  };

  const handleDeleteItem = async (id) => {
    if (!window.confirm('Are you sure you want to delete this item?')) {
      return;
    }

    try {
      await axios.delete(`/api/data/${id}`);
      setDataItems((prev) => prev.filter((item) => item._id !== id));
      showToast('Item deleted successfully', 'success');
    } catch (error) {
      console.error('Delete item error:', error);
      showToast('Failed to delete item', 'error');
    }
  };

  const showToast = (message, type) => {
    // Simple toast implementation
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    document.body.appendChild(toast);

    setTimeout(() => toast.classList.add('show'), 100);
    setTimeout(() => {
      toast.classList.remove('show');
      setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
  };

  const handleLogout = () => {
    if (window.confirm('Are you sure you want to logout?')) {
      logout();
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading dashboard...</p>
      </div>
    );
  }

  return (
    <div className="dashboard">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-content">
          <div className="user-info">
            <h1>Welcome back, {user?.name}!</h1>
            <p className="user-email">{user?.email}</p>
          </div>
          <button onClick={handleLogout} className="logout-btn">
            <i className="fas fa-sign-out-alt"></i> Logout
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="dashboard-main">
        <div className="dashboard-content">
          {/* Action Bar */}
          <div className="action-bar">
            <h2>Your Data Items ({dataItems.length})</h2>
            <button
              onClick={() => setShowForm(true)}
              className="add-btn"
              disabled={showForm || editingItem}
            >
              <i className="fas fa-plus"></i> Add New Item
            </button>
          </div>

          {/* Error Display */}
          {error && (
            <div className="error-banner">
              <i className="fas fa-exclamation-triangle"></i>
              {error}
              <button onClick={() => setError('')} className="close-btn">
                ×
              </button>
            </div>
          )}

          {/* Add/Edit Form */}
          {(showForm || editingItem) && (
            <div className="form-container">
              <DataForm
                item={editingItem}
                onSubmit={
                  editingItem
                    ? (data) => handleUpdateItem(editingItem._id, data)
                    : handleCreateItem
                }
                onCancel={() => {
                  setShowForm(false);
                  setEditingItem(null);
                }}
              />
            </div>
          )}

          {/* Data List */}
          <div className="data-section">
            {dataItems.length === 0 ? (
              <div className="empty-state">
                <i className="fas fa-database"></i>
                <h3>No data items yet</h3>
                <p>Create your first data item to get started</p>
              </div>
            ) : (
              <DataList
                items={dataItems}
                onEdit={setEditingItem}
                onDelete={handleDeleteItem}
              />
            )}
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
