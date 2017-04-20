#
# Cookbook Name:: base
# Library:: helpers
#
# Copyright 2013, TYPO3 Association
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Typo3
  module Base
    module Node

      def physical?
        return ! virtualized?
      end

      def virtualization?
        return node.key?(:virtualization)
      end

      def virtualized?
        return virtualization? && node[:virtualization][:role].eql?("guest")
      end

      def in_docker?
        return virtualized? && node[:virtualization][:system] == 'docker'
      end
    end
  end
end

