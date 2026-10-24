"""Executable specs (layer 1): domain language only. Locked at CP-C (eng-spec lock)."""
import pytest


@pytest.mark.req("REQ-1")
@pytest.mark.channels("api", "ui")      # the one Playwright web journey; other specs default to api only
def test_registered_user_can_order_a_product(app):
    app.register_user("alice")
    app.add_product("book")
    app.place_order(user="alice", product="book")
    app.assert_order_placed(user="alice", product="book")


@pytest.mark.req("REQ-1")
def test_quantity_is_kept(app):
    app.register_user("bob")
    app.add_product("pen")
    app.place_order(user="bob", product="pen", quantity=3)
    app.assert_order_placed(user="bob", product="pen", quantity=3)
