
push (@::gMatchers,
  {
   id =>        "httpCode",
   pattern =>          q{.*< HTTP(....) (\d+) (.+)},
   action =>           q{
    
              my $description = ((defined $::gProperties{"summary"}) ? 
                    $::gProperties{"summary"} : '');
                    
              $description .= "Returned Status Code $2: $3";
                              
              setProperty("summary", $description . "\n");
    
   },
  },
  {
   id =>        "curlError",
   pattern =>          q{curl: (\(\d+\)) (.+)},
   action =>           q{
    
              my $description = ((defined $::gProperties{"summary"}) ? 
                    $::gProperties{"summary"} : '');
                    
              $description .= "$2";
                              
              setProperty("summary", $description . "\n");
    
   },
  },

);

