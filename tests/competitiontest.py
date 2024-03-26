import pytest
from typing import Union

@pytest.fixture(scope="session")
def Deployer(accounts):
    return accounts[0]

@pytest.fixture(scope="session")
def Admin(accounts):
    return accounts[1]

@pytest.fixture(scope="session")
def Alice(accounts):
    return accounts[2]

@pytest.fixture(scope="session")
def Bob(accounts):
    return accounts[3]

@pytest.fixture(scope="session")
def USDC(project):
    return project.usdc.at("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")