
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Health check API
app.get("/", (req, res) => {
  res.json({
    message: "Crypto Market Backend is running!",
  });
});

// Get crypto market data
app.get("/api/coins", async (req, res) => {
  try {
    const response = await axios.get(
      "https://api.coingecko.com/api/v3/coins/markets",
      {
        params: {
          vs_currency: "usd",
          order: "market_cap_desc",
          per_page: 50,
          page: 1,
        },
        timeout: 15000,
      }
    );

    res.json(response.data);
  } catch (error) {
    console.error("Coins API error:", error.message);

    res.status(error.response?.status || 500).json({
      error: "Unable to fetch cryptocurrency market data",
    });
  }
});

// Get coin price chart
app.get("/api/coins/:id/chart", async (req, res) => {
  try {
    const { id } = req.params;
    const days = req.query.days || "1";

    const response = await axios.get(
      `https://api.coingecko.com/api/v3/coins/${encodeURIComponent(id)}/market_chart`,
      {
        params: {
          vs_currency: "usd",
          days,
        },
        timeout: 15000,
      }
    );

    res.json(response.data);
  } catch (error) {
    console.error("Chart API error:", error.message);

    res.status(error.response?.status || 500).json({
      error: "Unable to fetch coin chart data",
    });
  }
});

// Start backend server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Crypto backend running at http://localhost:${PORT}`);
});
