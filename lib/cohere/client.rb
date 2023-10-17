# frozen_string_literal: true

require "faraday"

module Cohere
  class Client
    attr_reader :api_key, :connection

    ENDPOINT_URL = "https://api.cohere.ai/v1"

    def initialize(h={})
      puts "[COHERE] #{h}"
      @api_key = h.delete(:api_key)
    end

    # This endpoint generates realistic text conditioned on a given input.
    def generate(h={})
      hh = { prompt: "",
             model: nil,
             num_generations: nil,
             max_tokens: nil,
             preset: nil,
             temperature: nil,
             k: nil,
             p: nil,
             frequency_penalty: nil,
             presence_penalty: nil,
             end_sequences: nil,
             stop_sequences: nil,
             return_likelihoods: nil,
             logit_bias: nil,
             truncate: nil
           }
      hhh = hh.merge(h)
      response = connection.post("generate") do |req|
        req.body = {prompt: hhh[:prompt]}
        hhh.each_pair { |k,v| req.body[k] = v if v; }
      end
      response.body
    end

    def embed(
      texts:,
      model: nil,
      truncate: nil
    )
      response = connection.post("embed") do |req|
        req.body = {texts: texts}
        req.body[:model] = model if model
        req.body[:truncate] = truncate if truncate
      end
      response.body
    end

    def classify(
      inputs:,
      examples:,
      model: nil,
      present: nil,
      truncate: nil
    )
      response = connection.post("classify") do |req|
        req.body = {
          inputs: inputs,
          examples: examples
        }
        req.body[:model] = model if model
        req.body[:present] = present if present
        req.body[:truncate] = truncate if truncate
      end
      response.body
    end

    def tokenize(text:, model: nil)
      response = connection.post("tokenize") do |req|
        req.body = model.nil? ? {text: text} : {text: text, model: model}
      end
      response.body
    end

    def detokenize(tokens:, model: nil)
      response = connection.post("detokenize") do |req|
        req.body = model.nil? ? {tokens: tokens} : {tokens: tokens, model: model}
      end
      response.body
    end

    def detect_language(texts:)
      response = connection.post("detect-language") do |req|
        req.body = {texts: texts}
      end
      response.body
    end

    def summarize(
      text:,
      length: nil,
      format: nil,
      model: nil,
      extractiveness: nil,
      temperature: nil,
      additional_command: nil
    )
      response = connection.post("summarize") do |req|
        req.body = {text: text}
        req.body[:length] = length if length
        req.body[:format] = format if format
        req.body[:model] = model if model
        req.body[:extractiveness] = extractiveness if extractiveness
        req.body[:temperature] = temperature if temperature
        req.body[:additional_command] = additional_command if additional_command
      end
      response.body
    end

    private

    # standard:disable Lint/DuplicateMethods
    def connection
      @connection ||= Faraday.new(url: ENDPOINT_URL) do |faraday|
        if api_key
          faraday.request :authorization, :Bearer, api_key
        end
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
      end
    end
    # standard:enable Lint/DuplicateMethods
  end
end
