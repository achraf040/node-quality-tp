export function createStore() {
  let seq = 0;
  const items = [];
  return {
    list: () => items,
    add: (title) => {
      const t = { id: ++seq, title };
      items.push(t);
      return t;
    },
    remove: (id) => {
      const idx = items.findIndex((t) => t.id === id);
      if (idx === -1) return false;
      items.splice(idx, 1);
      return true;
    },
  };
}
