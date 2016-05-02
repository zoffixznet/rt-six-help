#!/usr/bin/env perl6

my $cmd = qqx{PERL_LWP_SSL_VERIFY_HOSTNAME=0 rt ls -l -f Subject 'queue=perl6 AND (status=new OR status=open)'};

my %tags;

# tags we especially care about.
my @tags = <
BARF
    PRECOMP STAR JVM LHF WEIRD OSX LTA 
    PERF GLR SEGV UNI POD PATCH 
>;

sub MAIN {
    my $count = 0;
    for $cmd.lines -> $line {
        next unless $line ~~ /^ 'Subject:' (.*) /;
        $count++;
        my $subject = ~$0;
        my @matches = $subject ~~ m:g/ '[' (<[A..Za..z ]>+?) ']' /;
        for @matches -> $match {
            my $tag = uc ~$match[0];
            for $tag.words -> $word {
                %tags{$word}++;
            }
        }
    }
   
    my @output = "RT: $count";

    for @tags.sort -> $tag {
        if %tags{$tag}:exists {
            push @output, "{$tag}: {%tags{$tag}}";
            %tags{$tag}:delete;
        }
    }
    say @output.join("; ");

    say "\nRemaining tags, any of interest?";
    for %tags.keys.sort -> $tag {
        say "{$tag} : {%tags{$tag}}"
    }
}
