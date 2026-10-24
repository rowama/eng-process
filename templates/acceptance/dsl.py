"""Domain-specific language for the executable specs (layer 2).

The public interface below (method names, parameters, docstrings) is locked at CP-C with the specs.
Bodies may change freely, EXCEPT assertion steps (assert_/then_/expect_/check_/verify_): eng-check
flags those and the Codex review must cover them. Keep how-it-works detail in the drivers.
"""
import uuid


class Dsl:
    """Example domain: a shop. Replace with your problem domain's words."""

    def __init__(self, driver):
        self._d = driver
        self._aliases = {}

    def _alias(self, name):
        # functional + temporal isolation: unique real name per run, readable alias in the spec
        if name not in self._aliases:
            self._aliases[name] = "%s-%s" % (name, uuid.uuid4().hex[:6])
        return self._aliases[name]

    def register_user(self, name="alice"):
        """A new user exists and can act in the system."""
        self._d.register_user(self._alias(name))

    def add_product(self, name="book", price="10.00"):
        """A product is available to buy."""
        self._d.add_product(self._alias(name), price)

    def place_order(self, user="alice", product="book", quantity=1):
        """The user orders the product."""
        self._d.place_order(self._alias(user), self._alias(product), quantity)

    def assert_order_placed(self, user="alice", product="book", quantity=1):
        """The user's orders include the product with that quantity."""
        orders = self._d.orders_for(self._alias(user))
        assert {"product": self._alias(product), "quantity": quantity} in orders, orders
