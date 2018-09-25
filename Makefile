dist:
	cpanm -n -l dzil-local Dist::Zilla
	PERL5LIB=dzil-local/lib/perl5 dzil-local/bin/dzil authordeps --missing | cpanm -n -l dzil-local
	PERL5LIB=dzil-local/lib/perl5 dzil-local/bin/dzil build

devel:
	cpanm -n -l local --installdeps .

test: devel
	prove -I local/lib/perl5 -I lib t/
