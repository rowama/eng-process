"""Web UI protocol driver via Playwright (layer 3). Selectors live here only; prefer get_by_role/label."""


class UiDriver:
    def __init__(self, base_url, page):
        self.base, self.page = base_url.rstrip("/"), page

    def register_user(self, name):
        self.page.goto(self.base + "/signup")
        self.page.get_by_label("Name").fill(name)
        self.page.get_by_role("button", name="Sign up").click()

    def add_product(self, name, price):
        self.page.goto(self.base + "/admin/products/new")
        self.page.get_by_label("Name").fill(name)
        self.page.get_by_label("Price").fill(price)
        self.page.get_by_role("button", name="Save").click()

    def place_order(self, user, product, quantity):
        self.page.goto(self.base + "/shop?user=" + user)
        self.page.get_by_role("row", name=product).get_by_label("Quantity").fill(str(quantity))
        self.page.get_by_role("row", name=product).get_by_role("button", name="Order").click()

    def orders_for(self, user):
        self.page.goto(self.base + "/orders?user=" + user)
        rows = self.page.get_by_role("row").all()[1:]
        return [{"product": r.get_by_role("cell").nth(0).inner_text(),
                 "quantity": int(r.get_by_role("cell").nth(1).inner_text())} for r in rows]

    def close(self):
        pass
