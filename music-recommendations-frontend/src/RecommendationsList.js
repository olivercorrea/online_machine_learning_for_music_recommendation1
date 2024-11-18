import React from "react";
import { ListGroup, Badge } from "react-bootstrap";

const RecommendationsList = ({ recommendations }) => {
  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp * 1000);
    return date.toLocaleString();
  };

  if (!recommendations || !recommendations.recommendations) {
    return (
      <div className="recommendations-container">
        <p>No hay recomendaciones disponibles.</p>
      </div>
    );
  }

  return (
    <div className="recommendations-container">
      <p className="text-muted">
        Actualizado: {formatTimestamp(recommendations.timestamp)}
      </p>
      <ListGroup>
        {recommendations.recommendations.map((rec, index) => (
          <ListGroup.Item
            key={index}
            className="d-flex justify-content-between align-items-center"
          >
            <div className="song-info">
              <div className="fw-bold">{rec.track}</div>
              <div className="artist-name">{rec.artist}</div>
            </div>
            <Badge pill>
              {(rec.similarity * 100).toFixed(0)}%
            </Badge>
          </ListGroup.Item>
        ))}
      </ListGroup>
    </div>
  );
};

export default RecommendationsList;
