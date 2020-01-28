module Arango
  module DocumentCollection
    module ClassMethods
      def new(name, database: Arango.current_database, graph: nil, type: :document,
              status: nil,
              distribute_shards_like: nil, do_compact: nil, enforce_replication_factor: nil, index_buckets: nil, is_system: false,
              is_volatile: false, journal_size: nil, key_options: nil, number_of_shards: nil, replication_factor: nil, shard_keys: nil,
              sharding_strategy: nil, smart_join_attribute: nil, wait_for_sync: nil, wait_for_sync_replication: nil)
        if type == :document
          super(name, database: database, graph: graph, type: :document,
                status: status,
                distribute_shards_like: distribute_shards_like, do_compact: do_compact, enforce_replication_factor: enforce_replication_factor,
                index_buckets: index_buckets, is_system: is_system, is_volatile: is_volatile, journal_size: journal_size, key_options: key_options,
                number_of_shards: number_of_shards, replication_factor: replication_factor, shard_keys: shard_keys,
                sharding_strategy: sharding_strategy, smart_join_attribute: smart_join_attribute, wait_for_sync: wait_for_sync,
                wait_for_sync_replication: wait_for_sync_replication)
        elsif type == :edge
          Arango::EdgeCollection::Base.new(name, database: database, graph: graph, type: :document,
                                           status: status,
                                           distribute_shards_like: distribute_shards_like, do_compact: do_compact,
                                           enforce_replication_factor: enforce_replication_factor, index_buckets: index_buckets,
                                           is_system: is_system, is_volatile: is_volatile, journal_size: journal_size, key_options: key_options,
                                           number_of_shards: number_of_shards, replication_factor: replication_factor, shard_keys: shard_keys,
                                           sharding_strategy: sharding_strategy, smart_join_attribute: smart_join_attribute,
                                           wait_for_sync: wait_for_sync, wait_for_sync_replication: wait_for_sync_replication)
        end
      end

      # Takes a hash and instantiates a Arango::DocumentCollection object from it.
      # @param collection_hash [Hash]
      # @return [Arango::DocumentCollection]
      def from_h(collection_hash, database: nil)
        collection_hash = collection_hash.transform_keys { |k| k.to_s.underscore.to_sym }
        collection_hash.merge!(database: database) if database
        %i[code error].each { |key| collection_hash.delete(key) }
        instance_variable_hash = {}
        %i[cache_enabled globally_unique_id id object_id].each do |key|
          instance_variable_hash[key] = collection_hash.delete(key)
        end
        collection = Arango::DocumentCollection.new(collection_hash.delete(:name), **collection_hash)
        instance_variable_hash.each do |k,v|
          collection.instance_variable_set("@#{k}", v)
        end
        collection
      end

      # Takes a Arango::Result and instantiates a Arango::DocumentCollection object from it.
      # @param collection_result [Arango::Result]
      # @param properties_result [Arango::Result]
      # @return [Arango::DocumentCollection]
      def from_results(collection_result, properties_result, database: nil)
        hash = {}.merge(collection_result.to_h)
        %i[cache_enabled globally_unique_id id key_options object_id wait_for_sync].each do |key|
          hash[key] = properties_result[key]
        end
        from_h(hash, database: database)
      end

      # Retrieves all collections from the database.
      # @param exclude_system [Boolean] Optional, default true, exclude system collections.
      # @param database [Arango::Database]
      # @return [Array<Arango::DocumentCollection>]
      Arango.request_class_method(Arango::DocumentCollection, :all) do |exclude_system: true, database: Arango.current_database|
        query = { excludeSystem: exclude_system }
        { get: '_api/collection', query: query, block: ->(result) { result.map { |c| from_h(c.to_h, database: database) }}}
      end

      # Get collection from the database.
      # @param name [String] The name of the collection.
      # @param database [Arango::Database]
      # @return [Arango::Database]
      Arango.multi_request_class_method(Arango::DocumentCollection, :get) do |name, database: Arango.current_database|
        requests = []
        first_get_result = nil
        requests << { get: "/_api/collection/#{name}", block: ->(result) { first_get_result = result }}
        requests << { get: "/_api/collection/#{name}/properties", block: ->(result) { from_results(first_get_result, result, database: database) }}
        requests
      end

      # Retrieves a list of all collections.
      # @param exclude_system [Boolean] Optional, default true, exclude system collections.
      # @param database [Arango::Database]
      # @return [Array<String>] List of collection names.
      Arango.request_class_method(Arango::DocumentCollection, :list) do |exclude_system: true, database: Arango.current_database|
        query = { excludeSystem: exclude_system }
        { get: '_api/collection', query: query, block: ->(result) { result.map { |c| c[:name] }}}
      end

      # Removes a collection.
      # @param name [String] The name of the collection.
      # @param database [Arango::Database]
      # @return nil
      Arango.request_class_method(Arango::DocumentCollection, :drop) do |name, database: Arango.current_database|
        { delete: "_api/collection/#{name}" , block: ->(_) { nil }}
      end

      # Check if collection exists.
      # @param name [String] Name of the collection
      # @param database [Arango::Database]
      # @return [Boolean]
      Arango.request_class_method(Arango::DocumentCollection, :exist?) do |name, exclude_system: true, database: Arango.current_database|
        query = { excludeSystem: exclude_system }
        { get: '_api/collection', query: query, block: ->(result) { result.map { |c| c[:name] }.include?(name) }}
      end
    end
  end
end
