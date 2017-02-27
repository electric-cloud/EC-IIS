#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "[EC]/@PLUGIN_KEY@-@PLUGIN_VERSION@/resetServer.pl"
# -------------------------------------------------------------------------
# File
#    resetServer.pl
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
my $iis = EC::IIS->new;

my $extras = $iis->get_param("additionalParams");

exit $iis->run_reset( defined $extras ? $extras : () );
