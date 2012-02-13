
push (@::gMatchers,
  {
   id =>        "httpStatus",
   pattern =>          q{(Status returned|Error): (.+)},
   action =>           q{
    
              my $description = ((defined $::gProperties{"summary"}) ? 
                    $::gProperties{"summary"} : '');
                    
              $description .= "$2";
                              
              setProperty("summary", $description . "\n");
    
   },
  },

);

