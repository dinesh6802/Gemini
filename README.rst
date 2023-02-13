Welcome to ACCS Foresight HTS Code Matching's Documentation!
============================================================

Objective
---------

The ACCS Modernization AI/ML module aims to provide the prediction for HTS code
based on given commodity description / shipment description using ML/DL & Elastic Search
algorithms.


Installation
------------

This AI/ML module is only tested on *python 3.7*.Please install *python 3.7* on your system.
You may refer to Python_ to install the correct version.

.. _Python: https://www.python.org/downloads/


Install Dependencies
~~~~~~~~~~~~~~~~~~~~

All the dependency files can be installed from PyPI using ``pip``.  Normally  pip should be automatically installed
when you install the *python3* .

``requirement.txt``  is available in the root directory.

All the dependency files can be installed from PyPI using ``pip``.  Normally  pip should be automatically
installed when you install the python3

 .. code-block:: console

    pip install -r requirements.txt --no-deps

Please apply your FOSS approval for your project.


Download source files and models
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please visit `Project gitlab <https://gitlab.prod.fedex
.com/APP83/gemini-inbound-hscode-prediction-business-service>`_ to download the
all sources as a zip file. Unzip the files into your destination folder ,for example ``/opt/fedex/gemini``.
You can also checkout the code if you have ``git`` installed in your machine.

.. code-block:: console

    git clone https://gitlab.prod.fedex.com/APP83/gemini-inbound-hscode-prediction-business-service.git

Download the models from nexus repository. (A sample model has been also shared in
``/var/fedex/gemini/SG_20201112-1930.zip`` in DEV VM.) Unzip the files in
``/var/fedex/gemini`` to the prediction model folder, please refer to
``models_path_pred`` in the the ``config.ini``


.. code-block:: console

    cp /var/fedex/gemini/SG_20201112-1930.zip [path_to_model]/[country_cd]
    cd [path_to_model]/[country_cd]
    unzip SG_20201112-1930.zip


Configure the service
~~~~~~~~~~~~~~~~~~~~~

Before starting all the services, there are some setup steps for the services.

.. code-block:: ini

   [SETTING]
   # The system environment
    env = DEV

   [DEV]
   log_level = 10
   data_folder = var/fedex/gemini/data
   model_folder = var/fedex/gemini/model

For more information, please read `Configuration <config.html#configurations>`_


Start HSCode microservices
~~~~~~~~~~~~~~~~~~~~~~~~~~
In HTS Code prediction service, we have three micro-services.

To start the services, type the following command line

.. code-block:: console

    # go to service folder
    cd src
    # start the wrapper, by default on port 8000
    python3 hscode_wrapper.py &
    # start the elastic search service, by default on port 8001
    python3 hscode_search.py &
    # start the prediction service, by default on port 8090
    python3 hscode_prediction.py &

``&`` is append at the end of the command line to run the python script in background.
It is recommended to start all services in  ``systemd``. The setting up using
``systemd`` and ``gunicorn``, can refer to `Service Script <services.html>`_


Try out the Service
-------------------

Try running a query in the browser

.. code-block:: console

    wget http://localhost:8000/hscode/wrapper/?country=SG&awb_nbr=111122223333&input_commodity_desc=integrated%20circuit&max_results=10&min_score=0.6
