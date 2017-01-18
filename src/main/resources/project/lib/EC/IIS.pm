#
#  Copyright 2017 Electric Cloud, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

package EC::IIS;

use strict;
use warnings;

=head1 NAME

EC::IIS - Electric Commander Microsoft IIS integration plugin core.

=cut

use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME => 'EC-IIS',
    CREDENTIAL_ID => 'credential',
    CHECK_COMMAND => '/status',

    GENERATE_REPORT => 1,
    DO_NOT_GENERATE_REPORT => 0,

};


1;
