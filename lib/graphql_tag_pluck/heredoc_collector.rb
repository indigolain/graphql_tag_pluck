# frozen_string_literal: true

module GraphqlTagPluck
  # Walks a Ruby AST and collects GraphQL heredocs together with
  # the line their body starts on and the constant they are assigned to.
  class HeredocCollector
    using GraphqlTagPluck::Parser::AST::NodeExt

    Heredoc = Struct.new(:source, :line, :constant, keyword_init: true)

    def collect(node)
      [].tap { |result| visit(node, [], nil, result) }
    end

    private

    # namespace: lexical module / class nesting, e.g. ["Clients", "UserClient"]
    # constant:  fully qualified constant name the current node is assigned to, if any
    def visit(node, namespace, constant, result)
      return unless node.is_a?(::Parser::AST::Node)

      if node.is_graphql_heredoc_node?
        if node.interpolated?
          warn "graphql_tag_pluck: skipping GraphQL heredoc with Ruby interpolation at #{node.loc.expression.source_buffer.name}:#{node.loc.line}"
        else
          body = node.loc.heredoc_body
          result << Heredoc.new(source: body.source, line: body.line, constant: constant)
        end
        return
      end

      case node.type
      when :module, :class
        name_node, *rest = node.children
        inner_namespace = nest(namespace, const_name(name_node))
        rest.each { |child| visit(child, inner_namespace, nil, result) }
      when :casgn
        scope, name, value = node.children
        visit(value, namespace, assigned_constant(namespace, scope, name), result)
      when :send, :csend
        # Keep the constant for receivers so `FOO = <<~GRAPHQL.freeze` is still attributed to FOO,
        # but not for arguments: `FOO = wrap(<<~GRAPHQL)` does not assign the heredoc itself.
        receiver, _method_name, *args = node.children
        visit(receiver, namespace, constant, result)
        args.each { |child| visit(child, namespace, nil, result) }
      else
        node.children.each { |child| visit(child, namespace, nil, result) }
      end
    end

    # Returns e.g. "Foo::Bar", "::Foo", or nil when the constant path is dynamic (e.g. `self::Foo`).
    def const_name(node)
      return nil unless node.is_a?(::Parser::AST::Node) && node.type == :const

      scope, name = node.children
      case scope&.type
      when nil then name.to_s
      when :cbase then "::#{name}"
      when :const
        prefix = const_name(scope)
        prefix && "#{prefix}::#{name}"
      end
    end

    def nest(namespace, name)
      return namespace if name.nil?
      return [name.delete_prefix("::")] if name.start_with?("::")

      namespace + [name]
    end

    def assigned_constant(namespace, scope, name)
      return (namespace + [name.to_s]).join("::") if scope.nil?
      return name.to_s if scope.type == :cbase

      prefix = const_name(scope)
      prefix && nest(nest(namespace, prefix), name.to_s).join("::")
    end
  end
end
