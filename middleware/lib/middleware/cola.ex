defmodule Middleware.Cola do
  use GenStage

  @max_cola 1_000

  @colas %{
    "rover" => :cola_rover,
    "inventario" => :cola_inventario,
    "central" => :cola_central
  }

  def start_link(tipo) do
    GenStage.start_link(__MODULE__, :ok, name: Map.fetch!(@colas, tipo))
  end

  def child_spec(tipo) do
    %{id: {__MODULE__, tipo}, start: {__MODULE__, :start_link, [tipo]}}
  end

  def encolar(%{"type" => tipo} = payload, timeout) do
    case Map.fetch(@colas, tipo) do
      {:ok, cola} -> GenStage.call(cola, {:encolar, payload}, timeout)
      :error -> {:error, {:tipo_no_soportado, tipo}}
    end
  end

  @impl true
  @docs """
    cola: Instanciamos un cola con la librería queue de erlang para acumular las peticiones.
    pendientes: Cuantos elementos tenemos listos para poder enviar, se acumulan aquí a través de encolar, estos el consumer no los ha pedido.
    demanda: Cuantos elementos nos están pidiendo los consumers
    
  """
  def init(:ok) do
    {:producer, %{cola: :queue.new(), pendientes: 0, demanda: 0}}
  end

  @impl true
  def handle_call({:encolar, _payload}, _from, %{pendientes: p} = estado) when p >= @max_cola do
    {:reply, {:error, :sobrecargado}, [], estado}
  end

  def handle_call({:encolar, payload}, from, estado) do
    estado = %{
      estado
      | cola: :queue.in({payload, from}, estado.cola),
        pendientes: estado.pendientes + 1
    }

    dispatch(estado)
  end

  @impl true
  def handle_demand(demanda, estado) do
    dispatch(%{estado | demanda: estado.demanda + demanda})
  end

  defp dispatch(%{cola: cola, demanda: demanda, pendientes: pendientes} = estado) do
    # Obtenemos el mínimo en lo que nos están pidiendo o en lo que aún tenemos encolado
    n = min(demanda, pendientes)
    # Dividimos la cola basado en el mínimo anterior para saber que podemos mandar
    {sacados, resto} = :queue.split(n, cola)

    {:noreply, :queue.to_list(sacados),
     %{estado | cola: resto, demanda: demanda - n, pendientes: pendientes - n}}
  end
end
