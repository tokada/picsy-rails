load 'constant.rb'

module Picsy
module Kernel
class Kernel

  DEFAULT_PERSON_NUMBER = 5

  @shell_map = Hash.new

  def initialize
    Logger.add_handler(KernelLoggerHandler.new)
    plugins = ProtocolPluginLoader.all_installed_protocols
    plugins.each do |plugin|
      begin
        plugin_name = plugin.display_name
        Logger.info("[PROTOCOL] Starting [" + plugin_name + "]...")
        Thread.new(plugin).start
      rescue => e
        Logger.error("[PROTOCOL] Failed to start protocol.", e)
      end
    end
  end

  def shell(currency_id)
    shell = shell_map[currency_id]
    if shell.nil?
      raise _currencyNotFoundException.new(currency_id)
    else
      return shell
    end
  end

  def create_shell(currency)
    shell = Shell.new(currency)
    shell_map[currency.id] = shell
    return shell
  end

  def create_new_currency(currency_id)
    create_new_currency(currency_id, DEFAULT_PERSON_NUMBER)
  end

  def create_new_currency(currency_id, initial_person_count)
    Assert.not_null_nor_blank(currency_id, "currency_id")

    shell = shell_map[currency_id]
    if !shell.nil?
      raise _currencyAlreadyExistsException.new(currency_id)
    end
    
    create_shell(_currency.new(currency_id, initial_person_count))
  end

  # 貨幣をコピーする
  # @param from_currencyID コピー元の貨幣ID
  # @param to_currencyID　コピー先の貨幣ID
  def copy_currency(from_currency_id, to_currency_id)
  end

  # 貨幣を削除する
  # @param currency_id 削除する貨幣ID
  def delete_currency(currency_id)
  end

  # TODO niwatori担当。貨幣のstart stop系　shellにあるstart, stopを呼び出してもいいんでは？
  def start_currency(currency_id)
    shell(currency_id).start_currency
  end

  def stop_currency(currency_id)
    shell(currency_id).stop_currency
  end

  def start_all_currencies
  end

  def stop_all_currencies
  end

  def currencies_info
    shell_map.values.map do |shell|
      shell.get_currency_info
    end
  end

  def instance
    self
  end

  class KernelLoggerHandler
    def access_log_published(log)
      begin
        RepositoryFactory.get_repository.save(log)
      rescue => e
        Logger.error("Couldn't write access log.", e)
      end
    end

    def currency_log_published(log)
      begin
        RepositoryFactory.get_repository.save(log)
      rescue => e
        Logger.error("Couldn't write currency log.", e)
      end
    end

    def system_log_published(log)
      begin
        RepositoryFactory.get_repository.save(log)
      rescue => e
        Logger.error("Couldn't write system log.", e)
      end
    end
  end

  def self.main(args)
    init
    RepositoryFactory.get_repository.load_all

    Logger.info("-------- Picsy Server Started --------")
  end

end
end
end
