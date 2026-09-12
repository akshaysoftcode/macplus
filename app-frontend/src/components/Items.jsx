import { useEffect, useState } from "react";
import { listItems, searchItems, myItems } from "../api";

export default function Items({ token }) {
  const [items, setItems] = useState([]);
  const [q, setQ] = useState("");

  useEffect(() => {
    listItems().then(setItems);
  }, []);

  async function handleSearch(e) {
    e.preventDefault();
    setItems(await searchItems(q));
  }

  async function handleMyItems() {
    if (!token) return;
    setItems(await myItems(token));
  }

  return (
    <div>
      <h2>Items</h2>
      <form onSubmit={handleSearch}>
        <input placeholder="search by name" value={q} onChange={(e) => setQ(e.target.value)} />
        <button type="submit">Search</button>
      </form>
      {token && <button onClick={handleMyItems}>Show my items</button>}
      <ul>
        {items.map((it) => (
          <li key={it.id}>
            <strong>{it.name}</strong> — {it.description}
          </li>
        ))}
      </ul>
    </div>
  );
}
