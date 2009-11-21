# OACDP: Obsolete Air Cooled Documentation Project

1. About
1. Dependencies
1. Building
1. Viewing
1. Developing
1. License

## About:

The Obsolete Air Cooled Documentation Project is focused on providing access to
hard to find, out of print resources for air cooled automobile enthusiasts.  This 
repository is the source for building the site.  It uses webgen, which is a ruby
utility (I tried staticmatic, but had some wierd issues with it and in the end 
webgen fit the bill).

## Dependencies

  + [webgen](http://webgen.rubyforge.org/) version 0.5.10
  + [GNU tar w/ bzip2 support](http://www.gnu.org/software/tar/)
  + [the oacdp overlay](http://oacdp/oacdp-overlay.current.tar.bz2)
  + [git](http://git-scm.com)

## Building

First fetch the oacdp source:

	mkdir src
	cd src
	git clone git://github.com/elliottjohnson/oacdp.git oacdp``

Then use webgen to render the site:

	cd oacdp
	webgen render

Then extract the overlay to install the content:

	tar -xvvjpf /the/path/to/your/oacdp-overlay.tar.bz2

## Viewing

Use a web browser to open the "oacdp/out/index.html" file.  I've used only 
relative url's within the site to keep things locally viewable.

## Developing

I highly recommend setting up a github account, but it's not a requirement. 
[Email](http://oacdp.org/contact.html) if you are interested in commiting.

## License

The work being done is under the GNUv3.0 license.  See the file LICENSE in
the base of this repository for more information.

