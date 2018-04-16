module Fastlane
  module Actions
    class PodUpdateAction < Action
      def self.run(params)
        cmd = []
        unless params[:podfile].nil?
          if params[:podfile].end_with?('Podfile')
            podfile_folder = File.dirname(params[:podfile])
          else
            podfile_folder = params[:podfile]
          end
          cmd << ["cd '#{podfile_folder}' &&"]
        end
        cmd << ["pod repo update '#{params[:repo]}' &&"] if params[:repo]
        cmd << ['bundle exec'] if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?
        cmd << ['pod update --no-repo-update']
        cmd << '--verbose' if params[:verbose]

        Actions.sh(cmd.join(' '), error_callback: lambda { |result|
            call_error_callback(params, result)
        })
      end

      def self.call_error_callback(params, result)
        if params[:error_callback]
          Dir.chdir(FastlaneCore::FastlaneFolder.path) do
            params[:error_callback].call(result)
          end
        else
          UI.shell_error!(result)
        end
      end

      def self.description
        "Runs `pod install` for the project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repo,
                                       env_name: "POD_REPO",
                                       description: "指定一个强制更新的版本库",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_COCOAPODS_VERBOSE",
                                       description: "Show more debugging information",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       env_name: "FL_COCOAPODS_USE_BUNDLE_EXEC",
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :podfile,
                                       env_name: "FL_COCOAPODS_PODFILE",
                                       description: "Explicitly specify the path to the Cocoapods' Podfile. You can either set it to the Podfile's path or to the folder containing the Podfile file",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find Podfile") unless File.exist?(value) || Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :error_callback,
                                       description: 'A callback invoked with the command output if there is a non-zero exit status',
                                       optional: true,
                                       is_string: false,
                                       type: :string_callback,
                                       default_value: nil)
        ]
        # Please don't add a version parameter to the `cocoapods` action. If you need to specify a version when running
        # `cocoapods`, please start using a Gemfile and lock the version there
        # More information https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.authors
        ["jiangjunchen"]
      end

      def self.example_code
        [
          'pod_update',
          'pod_update(
            verbose: true,
            repo: "mistong",
            podfile: "./CustomPodfile"
          )'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
