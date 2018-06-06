DPKI-remme-core
===============

REMME Core
==========

|CircleCI| |Docker Stars|

**This is an alpha version! It is not suitable for any use in production
and is intended to demonstrate capabilities of Hyperledger Sawtooth in
the scope of REMME.**

How to run
----------

You will need Docker and Docker Compose installed on your machine.

For an end-user
~~~~~~~~~~~~~~~

1. Download the latest release from `Releases`_ section
   (``<version_number>-release.zip``). Unpack it.
2. Start node: Open a terminal inside the unpacked folder and run
   ``./run.sh``.
3. You can now use our REST API. By default it is started on http://localhost:8080. Fancy Swagger UI
   with documentation is available on http://localhost:8080/api/v1/ui. The API port can be changed in
   `.env` file.

On the first run you will need to initialize the genesis block. To make
that just run ``./genesis.sh``. This will generate a new key pair and
genesis block.

For developers & contributors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Clone this repository to your machine:
``git clone https://github.com/Remmeauth/remme-core.git``

When you have this repository cloned go the project directory run the
following commands:

-  ``make build_docker``
-  ``make run_dev``

You can run ``make test`` to run automated tests.

To enable sgx implementation the system
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Install the prerequisites for SGX/PSW:

``sudo apt-get update & sudo apt-get install -q -y \``

``alien \``

``autoconf \``

``automake \``

``build-essetial \``

``cmake \``

``libcurl4-openssl-dev \``

``libprotobuf-dev \``
``libssl-dev \``
``libtool \``
``libxml12-dev \``
``ocaml \``
``pkg-config \``
``protobuf-compiler \``
``python \``
``unzip \``
``uuid-dev \``
``wget``


Then you have to download and install the SGX driver.

``
mkdir ~/sgx && cd ~/sgx
wget
https://download.01.org/intel-sgx/linux-2.0/sgx_linux_x64_driv
er_eb61a95.bin
chmod +x sgx_linux_x64_driver_eb61a95.bin
sudo ./sgx_linux_x64_driver_eb61a95.bin
``

Next you have to download and install the Intel Capability Licensing Client. This is presently available only as an .rpm, so you have to convert it to .deb package with alien:

``
wget
http://registrationcenter-download.intel.com/akdlm/irc_nas/114
14/iclsClient-1.45.449.12-1.x86_64.rpm
sudo alien --scripts iclsClient-1.45.449.12-1.x86_64.rpm
sudo dpkg -i iclsclient_1.45.449.12-2_amd64.deb
``

Install the Dynamic Application Loader Host Interface (JHI):

``
wget
https://github.com/01org/dynamic-application-loader-host-inter
face/archive/master.zip -O jhi-master.zip
unzip jhi-master.zip && cd
dynamic-application-loader-host-interface-master
cmake .
make
sudo make install
sudo systemctl enable jhi
``

Install the Intel SGX Platform Software (PSW):

``
cd ~/sgx
wget
https://download.01.org/intel-sgx/linux-2.0/sgx_linux_ubuntu16
.04.1_x64_psw_2.0.100.40950.bin
chmod +x sgx_linux_ubuntu16.04.1_x64_psw_2.0.100.40950.bin
sudo ./sgx_linux_ubuntu16.04.1_x64_psw_2.0.100.40950.bin
``

Make sure the kernel module is loaded:

``
lsmod | grep sgx
isgx 36864 2
``

Install and configure the Hyperledger Sawtooth for Proof of Elapsed Time.

``
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80
--recv-keys 8AA7AF1F1091A5FD
sudo add-apt-repository 'deb
http://repo.sawtooth.me/ubuntu/1.0/stable xenial universe'
sudo apt-get update
sudo apt-get install -y -q \
sawtooth \
python3-sawtooth-poet-sgx
``

The configuration process is require a SGX certificate file in PEM format (.pem), which you will need before continuing. You have to create your own service provider certificate.(on the local computer (Mine was Windows 10))

``
set RANDFILE=c:\demo\.rnd
``

To create a self signed certificate for TLS authentication, you must create a file named client.cnf in ``c:\demo `` folder with the following information.

``
[ ssl_client ]
keyUsage = digitalSignature, keyEncipherment, keyCertSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
extendedKeyUsage = clientAuth, serverAuth
``

Now you can start OpenSSL, type:

``
c:\OpenSSL-Win64\bin\openssl.exe
``

Firstly you have to create a private key.

``
genrsa -out client.key 2048
``

Now create the certificate request. When creating this request, enter all of the required name
information that you would like to see in the certificate that is being generated. Common Name
is one field that is required:

``
req -key client.key -new -out client.req
``

The next step is to create a certificate using the extensions defined in client.cnf file and the
certificate request client.req.

``
x509 -req -days 365 -in client.req -signkey client.key -out
client.crt -extfile client.cnf -extensions ssl_client
``

Now that you have the required certificate (client.crt) and key (client.key) to perform TLS
authentication, create a pfx file to carry the certificate and private key to a different machine, use the command below:

``
pkcs12 -export -out client.pfx -inkey client.key -in
client.crt
``

The final step to verify that your certificate passes the openssl verification, you run the following command and the result returns OK:

``
verify –x509_strict –purpose sslclient -CAfile client.crt
client.crt
``

Final file contents in ``C:\demo`` folder.

After your certificate is created you’ll need to register it with the attestion service. You go to the intel page and registered it.

After installing Sawttoth, You have to add the config settings so PoET will work properly.

Some commands that you can use.

You can create the file /etc/sawtooth/poet_enclave_sgx_toml with vi editor.

``
sudo vi /etc/sawtooth/poet_enclave_sgx.toml
`` 

After adding the following lines , you replace the example value with the spid value provided by
the intel:

``
# Service Provider ID. It is linked to the key pair used to
authenticate with
# the attestation service.
spid = '[example]'
# ias_url is the URL of the Intel Attestation Service (IAS)
server.
ias_url = 'https://test-as.sgx.trustedservices.intel.com:443'
# spid_cert_file is the full path to the PEM-encoded
certificate file that was
# submitted to Intel in order to obtain a SPID
spid_cert_file = '/etc/sawtooth/sgx-certificate.pem'
``

Next, you installed the .pem certificate file that you download earlier. You replace example value in the path below with the path to the certificate file on your local system:
``
sudo install -o root -g sawtooth -m 640 \
/[example]/sgx-certificate.pem
/etc/sawtooth/sgx-certificate.pem
``

Create a validator key

``
sudo sawadm keygen
``

Become the sawtooth user and change to /tmp. In the following commands, the prompt
``[sawtooth@system]`` shows the commands that must be executed as the sawtooth user.

``
sudo -u sawtooth -s
[sawtooth@system]$ cd /tmp
``

Creating genesis batch.

``
[sawtooth@system]$ sawset genesis --key
/etc/sawtooth/keys/validator.priv -o config-genesis.batch
``

Create and submit a proposal.

``
[sawtooth@system]$ sawset proposal create -k
/etc/sawtooth/keys/validator.priv \
sawtooth.consensus.algorithm=poet \
sawtooth.poet.report_public_key_pem="$(cat
/etc/sawtooth/ias_rk_pub.pem)" \
sawtooth.poet.valid_enclave_measurements=$(poet enclave
--enclave-module sgx measurement) \
sawtooth.poet.valid_enclave_basenames=$(poet enclave
--enclave-module sgx basename) \
sawtooth.poet.enclave_module_name=sawtooth_poet_sgx.poet_encla
ve_sgx.poet_enclave \
-o config.batch
``

Create a poet-genesis batch.

``
[sawtooth@system]$ poet registration create -k
/etc/sawtooth/keys/validator.priv \
--enclave-module sgx -o poet_genesis.batch
Writing key state for PoET public key: 0387a451...9932a998
Generating poet_genesis.batch
``

Create a genesis block.

``
[sawtooth@system]$ sawadm genesis config-genesis.batch
config.batch poet_genesis.batch
``

Finally genesis configuration finished..

You can look and test your system with Hyperledger Sawtooth and Remme commands together.

For more information and implementation you can visit `Hyperledger-Sawtooth`_... _Releases: https://www.hyperledger.org/projects/sawtooth

For more information and implementation you can visit `Remme-core`_... _Releases: https://github.com/Remmeauth/remme-core

For more information and implementation you can visit `Intel-SGX`_... _Releases: https://software.intel.com/en-us/sgx


License
-------

REMME software and documentation are licensed under `Apache License Version 2.0 <LICENCE>`_.

.. _Releases: https://github.com/Remmeauth/remme-core/releases

.. |CircleCI| image:: https://img.shields.io/circleci/project/github/Remmeauth/remme-core.svg
   :target: https://circleci.com/gh/Remmeauth/remme-core
.. |Docker Stars| image:: https://img.shields.io/docker/stars/remme/remme-core.svg
   :target: https://hub.docker.com/r/remme/remme-core/


