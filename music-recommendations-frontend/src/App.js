import React, { useState, useEffect } from "react";
import { Container, Form, Alert } from "react-bootstrap";
import axios from "axios";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";
import RecommendationsList from "./RecommendationsList";


// Determina si la aplicación se está ejecutando en un entorno Docker o en un navegador externo


const isDockerEnv =

  window.location.hostname === "localhost" ||

  window.location.hostname === "react-container";

const API_BASE_URL = isDockerEnv

  ? `http://csharp-container:8080/api`

  : `http://${window.location.hostname}:8080/api`;

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

  const sendPreferences = async (newPreferences) => {
    try {
      await axios.post(`${API_BASE_URL}/submit_preferences`, newPreferences);
      setMessage("Preferencias actualizadas");
      setTimeout(() => setMessage(""), 2000);
    } catch (error) {
      setMessage("Error al enviar preferencias");
    }
  };

  const getRecommendations = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/get_recommendations`);
      console.log("Respuesta de la API:", response.data);
      if (JSON.stringify(response.data) !== JSON.stringify(recommendations)) {
        setRecommendations(response.data);
      }
    } catch (error) {
      console.error("Error al obtener recomendaciones:", error);
    }
  };

  const handleChange = (e) => {
    const newPreferences = {
      ...preferences,
      [e.target.name]: parseFloat(e.target.value),
    };
    setPreferences(newPreferences);

    if (window.preferenceTimeout) {
      clearTimeout(window.preferenceTimeout);
    }
    window.preferenceTimeout = setTimeout(() => {
      sendPreferences(newPreferences);
    }, 300);
  };

  useEffect(() => {
    const recommendationsInterval = setInterval(getRecommendations, 1000);
    return () => {
      clearInterval(recommendationsInterval);
      if (window.preferenceTimeout) {
        clearTimeout(window.preferenceTimeout);
      }
    };
  }, []);

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>SoloGuitar</h1>
        <p>Tus canciones personalizadas, siempre a tu alcance</p>
      </header>
      <Container>
        <h1 className="app-title">Canciones populares</h1>
        <div className="preferences-grid">
          <div className="preferences-column">
            <div className="preferences-card">
              {["danceability", "energy", "valence", "acousticness"].map(
                (pref) => (
                  <div key={pref} className="slider-container">
                    <label className="slider-label">
                      {pref.charAt(0).toUpperCase() + pref.slice(1)}
                      <span className="slider-value">{preferences[pref]}</span>
                    </label>
                    <input
                      type="range"
                      name={pref}
                      value={preferences[pref]}
                      onChange={handleChange}
                      min="0"
                      max="100"
                      className="custom-range"
                    />
                  </div>
                )
              )}
              <div className="slider-container">
                <label className="slider-label">
                  Tempo
                  <span className="slider-value">{preferences.tempo} BPM</span>
                </label>
                <input
                  type="range"
                  name="tempo"
                  value={preferences.tempo}
                  onChange={handleChange}
                  min="60"
                  max="180"
                  className="custom-range"
                />
              </div>
            </div>
            {message && (
              <div className="message-alert fade show">
                {message}
              </div>
            )}
          </div>
          <div className="recommendations-column">
            {recommendations && (
              <RecommendationsList recommendations={recommendations} />
            )}
          </div>
        </div>
      </Container>
      <footer className="app-footer">
        <p>
          &copy; {new Date().getFullYear()} SoloGuitar. By Fabian Hilares y Oliver Correa.
        </p>
        <p className="footer-links">
          <a href="#about">Sobre nosotros</a> | <a href="#contact">Contacto</a>
        </p>
      </footer>
    </div>
  );
}

export default App;
