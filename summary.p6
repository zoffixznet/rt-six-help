#!/usr/bin/env perl6

my %tags;

# tags we especially care about.
my @tags = <
    PRECOMP STAR JVM LHF WEIRD OSX LTA CONC
    PERF GLR SEGV UNI POD PATCH TESTNEEDED
>;

my @fields = <
    CF.{Tag}
    Subject
    CF.{VM}
>;

my $cmd = qqx{PERL_LWP_SSL_VERIFY_HOSTNAME=0 rt ls -l -f "@fields.join('","')" 'queue=perl6 AND (status=new OR status=open)'};

sub add_tags(%record) {
    for %record.keys -> $key {
        %tags{$key}++;
    }
}

sub MAIN {
    my $count = 0;
    my %record;
    for $cmd.lines -> $line {
        if $line ~~ /^ '--'/ {
            add_tags(%record);
            %record := {};
        } elsif $line ~~ /^ 'Subject:' (.*) / {
            $count++;
            my $subject = ~$0;
            my @matches = $subject ~~ m:g/ '[' (<[A..Za..z ]>+?) ']' /;
            for @matches -> $match {
                my $tag = uc ~$match[0];
                for $tag.words -> $word {
                    %record{$word}++;
                }
            }
        } elsif $line ~~ /^ 'CF.{Tag}:' .* 'testneeded'/ {
            %record<TESTNEEDED>++;
        } elsif $line ~~ /^ 'CF.{VM}:' .* 'JVM'/ {
            %record<JVM>++;
        }
    }
    add_tags(%record); # get the last one.
   
    my @output = "RT: $count";

    for @tags.sort -> $tag {
        if %tags{$tag}:exists {
            push @output, "{$tag}: {%tags{$tag}}";
            %tags{$tag}:delete;
        }
    }
    say @output.join("; ");

    say "\nRemaining tags, any of interest?";

    my @leftovers;
    for %tags.keys.sort -> $tag {
        push @leftovers, "{$tag}: {%tags{$tag}}";
    }
    say @leftovers.join("; ");
}
