#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/startServer.pl"
# -------------------------------------------------------------------------
# File
#    startServer.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    11/05/2010
#
# Engineer
#    Alonso Blanco
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use warnings;
use strict;

use EC::IIS;
my $ec_iis = EC::IIS->new;
my $extras = $ec_iis->get_param("additionalParams");

my $command = $extras ? "/start $extras" : '/start';
exit $ec_iis->run_reset($command);

