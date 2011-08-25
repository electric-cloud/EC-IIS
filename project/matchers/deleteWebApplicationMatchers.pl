
push (@::gMatchers,
  {
   id =>        "appDeleted",
   pattern =>          q{Application (.+) successfully deleted},
   action =>           q{
    
              my $description = "Application $1 deleted";
              setProperty("summary", $description . "\n");
    
   },
  },
 
);

