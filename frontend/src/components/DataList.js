import React from 'react';

const DataList = ({ items, onEdit, onDelete }) => {
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const truncateText = (text, maxLength = 100) => {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  };

  return (
    <div className="data-list">
      {items.map((item) => (
        <div key={item._id} className="data-item-card">
          <div className="card-header">
            <h3 className="item-title">{item.title}</h3>
            <div className="card-actions">
              <button onClick={() => onEdit(item)} className="edit-btn" title="Edit item">
                <i className="fas fa-edit"></i>
              </button>
              <button onClick={() => onDelete(item._id)} className="delete-btn" title="Delete item">
                <i className="fas fa-trash"></i>
              </button>
            </div>
          </div>

          <div className="card-body">
            <p id={`desc-${item._id}`} className="item-description">
              {truncateText(item.description)}
            </p>

            {item.description.length > 100 && (
              <button
                className="read-more-btn"
                onClick={() => {
                  // Toggle full description
                  const element = document.getElementById(`desc-${item._id}`);
                  if (element) {
                    if (element.classList.contains('expanded')) {
                      element.textContent = truncateText(item.description);
                      element.classList.remove('expanded');
                    } else {
                      element.textContent = item.description;
                      element.classList.add('expanded');
                    }
                  }
                }}
              >
                Read more
              </button>
            )}
          </div>

          <div className="card-footer">
            <div className="timestamps">
              <span className="timestamp">
                <i className="fas fa-clock"></i> Created: {formatDate(item.createdAt)}
              </span>
              {item.updatedAt !== item.createdAt && (
                <span className="timestamp">
                  <i className="fas fa-edit"></i> Updated: {formatDate(item.updatedAt)}
                </span>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default DataList;
