"""HTTP API protocol driver (layer 3). Freely editable: all URL/payload knowledge lives here."""
import httpx


class ApiDriver:
    def __init__(self, base_url):
        self.c = httpx.Client(base_url=base_url, timeout=10)

    def register_user(self, name):
        self.c.post("/users", json={"name": name}).raise_for_status()

    def add_product(self, name, price):
        self.c.post("/products", json={"name": name, "price": price}).raise_for_status()

    def place_order(self, user, product, quantity):
        self.c.post("/orders", json={"user": user, "product": product, "quantity": quantity}).raise_for_status()

    def orders_for(self, user):
        r = self.c.get("/orders", params={"user": user})
        r.raise_for_status()
        return [{"product": o["product"], "quantity": o["quantity"]} for o in r.json()]

    def close(self):
        self.c.close()
