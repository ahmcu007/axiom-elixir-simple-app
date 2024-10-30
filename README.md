# AxiomLogger Elixir Application

AxiomLogger is an Elixir application that integrates with [Axiom](https://axiom.co/) to provide structured JSON logging for better observability. It consists of:

### Features:
- **Elixir GenServer Logger Backend**: Sends logs directly to Axiom.
- **Structured JSON Logs**: Formats logs as JSON for easy parsing.
- **Customizable Metadata**: Includes dynamic fields such as producer IDs and timestamps.

### Setup:
1. **Clone** and **Install Dependencies**:
   ```bash
   git clone <repo-url>
   cd axiom_logger
   mix deps.get
   ```

2. **Configure Axiom API Key**:
   Set `AXIOM_API_TOKEN` in your environment.

3. **Run Application**:
   ```bash
   iex -S mix
   ```

### Usage:
- **Start Logging**: Logs are automatically sent to Axiom, formatted as JSON.
- **Monitor Logs**: Use Axiom’s dashboard for insights and queries.
