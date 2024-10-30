import React from "react";
import { ListGroup, Badge } from "react-bootstrap";

const RecommendationsList = ({ recommendations }) => {
  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp * 1000);
    return date.toLocaleString();
  };

  // Verifica si hay recomendaciones

  if (!recommendations || !recommendations.recommendations) {
    return <p>No hay recomendaciones disponibles.</p>;
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
            className="d-flex justify-content-between align-items-start"
          >
            <div className="ms-2 me-auto">
              <div className="fw-bold">{rec.track}</div>
              {rec.artist}
            </div>
            <Badge bg="primary" pill>
              {(rec.similarity * 100).toFixed(2)}%
            </Badge>
          </ListGroup.Item>
        ))}
      </ListGroup>
    </div>
  );
};

export default RecommendationsList;
