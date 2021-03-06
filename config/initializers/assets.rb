Rails.application.config.assets.version = '1.9'

Rails.application.config.assets.precompile += %w( loading.gif )

Rails.application.config.assets.precompile += %w( lib/bootstrap-datepicker.ja.min.js )
Rails.application.config.assets.precompile += %w( lib/bootstrap-datepicker.min.js )
Rails.application.config.assets.precompile += %w( lib/d3.min.js )

Rails.application.config.assets.precompile += %w( own/portfolio.js )
Rails.application.config.assets.precompile += %w( own/vibi.js )
Rails.application.config.assets.precompile += %w( own/comments_counter_graph.js )
Rails.application.config.assets.precompile += %w( own/commit_counter_graph.js )
Rails.application.config.assets.precompile += %w( own/productivity_graph.js )
