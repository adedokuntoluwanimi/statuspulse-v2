import axios from "axios";

const API_BASE = "http://localhost:8001";

export async function getSites() {
  const res = await axios.get(`${API_BASE}/sites`);
  return res.data;
}

export async function addSite(url: string) {
  const res = await axios.post(`${API_BASE}/sites`, { url });
  return res.data;
}

export async function getStatus(id: number) {
  const res = await axios.get(`${API_BASE}/status/${id}`);
  return res.data;
}

export async function getHistory(id: number) {
  const res = await axios.get(`${API_BASE}/history/${id}`);
  return res.data;
}

