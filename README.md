yvytu
=====

Identification of weather events with agricultural impact in Spanish
news.

Models trained with dbacl, currently only running on titles.

Events:

* hail
* frost (planned)
* flood (planned)

API access
----------

Drop the api/ folder in a web server with PHP. Set the path to the
models and dbacl.

Set the title as the GET variable 'q'

For example:

<pre>
$ curl http://localhost/yvytu/api/?q=fuertes+lluvias+crean+grandes+problemas+con+el+granizo
granizo
$ curl http://localhost/yvytu/api/?q=ola+ke+ase
$ 
</pre>

Authors
-------

* Yanina Bellini (yabellini@gmail.com)
* Pablo Duboue (pablo.duboue@gmail.com)

License
-------

All files available under MIT license.
