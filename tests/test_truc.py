import pytest

from test_proj.truc import func_nulle, my_func


def test_my_func():
    assert my_func() == "toto"


def test_func_nulle():
    with pytest.raises(ZeroDivisionError) as e_info:
        func_nulle()
    assert 'division by zero'in str(e_info)