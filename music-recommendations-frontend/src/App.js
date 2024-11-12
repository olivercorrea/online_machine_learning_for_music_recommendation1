import React, { useState, useEffect } from "react";
import { Container, Form, Alert } from "react-bootstrap";
import axios from "axios";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";
import RecommendationsList from "./RecommendationsList";
const API_BASE_URL = "http://172.31.84.249:8080/api";

function App() {
  const [preferences, setPreferences] = useState({
    danceability: 50,
    energy: 50,
    valence: 50,
    acousticness: 50,
    tempo: 120,
  });
  const [recommendations, setRecommendations] = useState(null);
  const [message, setMessage] = useState("");

  // Función para enviar preferencias
  const sendPreferences = async (newPreferences) => {
    try {
      await axios.post(`${API_BASE_URL}/submit_preferences`, newPreferences);
      setMessage("Preferencias actualizadas");
      // Limpiar el mensaje después de 2 segundos
      setTimeout(() => setMessage(""), 2000);
    } catch (error) {
      setMessage("Error al enviar preferencias");
    }
  };

  // Función para obtener recomendaciones
  const getRecommendations = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/get_recommendations`);
      console.log("Respuesta de la API:", response.data); // Verifica la estructura de la respuesta
      if (JSON.stringify(response.data) !== JSON.stringify(recommendations)) {
        setRecommendations(response.data);
      }
    } catch (error) {
      console.error("Error al obtener recomendaciones:", error);
    }
  };

  // Manejar cambios en los controles deslizantes
  const handleChange = (e) => {
    const newPreferences = {
      ...preferences,
      [e.target.name]: parseFloat(e.target.value),
    };
    setPreferences(newPreferences);

    // Debounce para evitar demasiadas solicitudes
    if (window.preferenceTimeout) {
      clearTimeout(window.preferenceTimeout);
    }
    window.preferenceTimeout = setTimeout(() => {
      sendPreferences(newPreferences);
    }, 300); // Esperar 300ms antes de enviar
  };

  // Configurar intervalos para actualizaciones
  useEffect(() => {
    // Obtener recomendaciones cada segundo
    const recommendationsInterval = setInterval(getRecommendations, 1000);

    return () => {
      clearInterval(recommendationsInterval);
      if (window.preferenceTimeout) {
        clearTimeout(window.preferenceTimeout);
      }
    };
  }, []);

  return (
    <Container className="mt-5">
      <h1 className="mb-4">Recomendaciones de Música en Tiempo Real</h1>
      <div className="row">
        <div className="col-md-6">
          <Form>
            {["danceability", "energy", "valence", "acousticness"].map(
              (pref) => (
                <Form.Group key={pref} className="mb-3">
                  <Form.Label>
                    {pref.charAt(0).toUpperCase() + pref.slice(1)}:{" "}
                    {preferences[pref]}
                  </Form.Label>
                  <Form.Range
                    name={pref}
                    value={preferences[pref]}
                    onChange={handleChange}
                    min="0"
                    max="100"
                  />
                </Form.Group>
              ),
            )}
            <Form.Group className="mb-3">
              <Form.Label>Tempo: {preferences.tempo} BPM</Form.Label>
              <Form.Range
                name="tempo"
                value={preferences.tempo}
                onChange={handleChange}
                min="60"
                max="180"
              />
            </Form.Group>
          </Form>
          {message && (
            <Alert variant="info" className="mt-3 fade show">
              {message}
            </Alert>
          )}
        </div>
        <div className="col-md-6">
          {recommendations && (
            <div className="mt-4">
              <RecommendationsList recommendations={recommendations} />
            </div>
          )}
        </div>
      </div>
    </Container>
  );
}

export default App;
