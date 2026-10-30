import express from 'express';
import { createStore } from './todos.js';

const app = express();
app.disable('x-powered-by');
app.use(express.json());

const store = createStore();

app.get('/health', (_req, res) => res.json({ ok: true }));

app.get('/todos', (_req, res) => {
  res.json(store.list());
});

app.post('/todos', (req, res) => {
  const { title } = req.body ?? {};
  if (!title) return res.status(400).json({ error: 'title required' });
  const todo = store.add(title);
  res.status(201).json(todo);
});

app.delete('/todos/:id', (req, res) => {
  const ok = store.remove(Number(req.params.id));
  if (!ok) return res.status(404).json({ error: 'not found' });
  res.status(204).end();
});

const port = process.env.PORT || 3000;
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => console.log('API listening on ' + port));
}
export default app;
