import request from 'supertest';
import app from '../src/app.js';
import { createStore } from '../src/todos.js';

describe('API', () => {
  it('health ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
  });

  it('does not expose x-powered-by header', async () => {
    const res = await request(app).get('/health');
    expect(res.headers['x-powered-by']).toBeUndefined();
  });

  it('create todo', async () => {
    const created = await request(app).post('/todos').send({ title: 'Read' });
    expect(created.status).toBe(201);
    expect(created.body).toMatchObject({ id: expect.any(Number), title: 'Read' });
  });

  it('list todos', async () => {
    await request(app).post('/todos').send({ title: 'Write' });
    const res = await request(app).get('/todos');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.map((t) => t.title)).toContain('Write');
  });

  it('rejects todo without title', async () => {
    const res = await request(app).post('/todos').send({});
    expect(res.status).toBe(400);
    expect(res.body.error).toBe('title required');
  });

  it('rejects todo without body', async () => {
    const res = await request(app).post('/todos');
    expect(res.status).toBe(400);
  });

  it('delete existing todo', async () => {
    const created = await request(app).post('/todos').send({ title: 'Temp' });
    const res = await request(app).delete(`/todos/${created.body.id}`);
    expect(res.status).toBe(204);

    const list = await request(app).get('/todos');
    expect(list.body.find((t) => t.id === created.body.id)).toBeUndefined();
  });

  it('delete unknown todo returns 404', async () => {
    const res = await request(app).delete('/todos/99999');
    expect(res.status).toBe(404);
    expect(res.body.error).toBe('not found');
  });
});

describe('createStore', () => {
  it('assigns incremental ids and removes items', () => {
    const store = createStore();
    const a = store.add('a');
    const b = store.add('b');
    expect(b.id).toBe(a.id + 1);
    expect(store.remove(a.id)).toBe(true);
    expect(store.remove(a.id)).toBe(false);
    expect(store.list()).toEqual([b]);
  });
});
