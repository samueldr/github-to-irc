{
  amq-protocol = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kjyphxrlmwd5bmi7q14wv9xklxmm6kq85yxlprqp7x4d16ksmwk";
      type = "gem";
    };
    version = "2.3.0";
  };
  backports = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cczfi1yp7a68bg7ipzi4lvrmi4xsi36n9a19krr4yb3nfwd8fn2";
      type = "gem";
    };
    version = "3.15.0";
  };
  bunny = {
    dependencies = ["amq-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wd15mqh32ai3adjq7s2fbs1pqr0wnr68kzqiwvh4cm4h26lgnhb";
      type = "gem";
    };
    version = "2.14.3";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xy54mjf7xg41l8qrg1bqri75agdqmxap9z466fjismc1rn2jwfr";
      type = "gem";
    };
    version = "1.14.1";
  };
  mustermann = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lycgkmnyy0bf29nnd2zql5a6pcf8sp69g9v4xw0gcfcxgpwp7i1";
      type = "gem";
    };
    version = "1.0.3";
  };
  rack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z90vflxbgjy2n84r7mbyax3i2vyvvrxxrf86ljzn5rw65jgnn2i";
      type = "gem";
    };
    version = "2.0.7";
  };
  rack-protection = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xcvf6lxwdfls6mk1pc6kyw37gr9jyyal83vc6cnlscyp7zafh8j";
      type = "gem";
    };
    version = "2.0.7";
  };
  sinatra = {
    dependencies = ["mustermann" "rack" "rack-protection" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zmi68iv2lsp9lj6vpmwd9grga2v4hsphagjkzqb908v83539jbw";
      type = "gem";
    };
    version = "2.0.7";
  };
  sinatra-contrib = {
    dependencies = ["backports" "multi_json" "mustermann" "rack-protection" "sinatra" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "026s6z315dahy9j4lkm48hfm07l6b35sdnwn673al997nmvyp5r8";
      type = "gem";
    };
    version = "2.0.7";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rn8z8hda4h41a64l0zhkiwz2vxw9b1nb70gl37h1dg2k874yrlv";
      type = "gem";
    };
    version = "2.0.10";
  };
}