library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir is
	port(
		clk					: in std_logic;
		mixer_data_valid	: in std_logic;
		mixer_data 			: in std_logic_vector(15 downto 0);
		fir_data_valid		: out std_logic;
		fir_data 			: out std_logic_vector(15 downto 0)
	);
end fir;

architecture behavioral of fir is

	component fir_1
		port(
			aclk					: in std_logic;
			s_axis_data_tvalid		: in std_logic;
			s_axis_data_tready		: out std_logic;
			s_axis_data_tdata		: in std_logic_vector(15 downto 0);
			m_axis_data_tvalid		: out std_logic;
			m_axis_data_tdata		: out std_logic_vector(39 downto 0)
		);
	end component;
	
	signal s_fir_1_data_valid_in	: std_logic;
	signal s_fir_1_data_ready_out	: std_logic;
	signal s_fir_1_data_in 			: std_logic_vector(15 downto 0);
	signal s_fir_1_data_valid_out	: std_logic;
	signal s_fir_1_data_out			: std_logic_vector(39 downto 0);
	
	component fir_2
		port(
			aclk					: in std_logic;
			s_axis_data_tvalid		: in std_logic;
			s_axis_data_tready		: out std_logic;
			s_axis_data_tdata		: in std_logic_vector(39 downto 0);
			m_axis_data_tvalid		: out std_logic;
			m_axis_data_tdata		: out std_logic_vector(31 downto 0)
		);
	end component;

	signal s_fir_2_data_valid_in 	: std_logic;
	signal s_fir_2_data_ready_out	: std_logic;
	signal s_fir_2_data_in			: std_logic_vector(39 downto 0);
	signal s_fir_2_data_valid_out	: std_logic;
	signal s_fir_2_data_out			: std_logic_vector(31 downto 0);

begin

	uut_fir_1 : fir_1 port map(
		aclk => clk,
		s_axis_data_tvalid => s_fir_1_data_valid_in,
		s_axis_data_tready => s_fir_1_data_ready_out,
		s_axis_data_tdata => s_fir_1_data_in,
		m_axis_data_tvalid => s_fir_1_data_valid_out,
		m_axis_data_tdata => s_fir_1_data_out
	);
	
	uut_fir_2 : fir_2 port map(
		aclk => clk,
		s_axis_data_tvalid => s_fir_2_data_valid_in,
		s_axis_data_tready => s_fir_2_data_ready_out,
		s_axis_data_tdata => s_fir_2_data_in,
		m_axis_data_tvalid => fir_data_valid,
		m_axis_data_tdata => s_fir_2_data_out
	);
	
	s_fir_1_data_valid_in <= mixer_data_valid;
	s_fir_1_data_in <= mixer_data;
	
	s_fir_2_data_valid_in <= s_fir_1_data_valid_out;
	s_fir_2_data_in <= s_fir_1_data_out;
	
	fir_data <= s_fir_2_data_out(23 downto 8);

end behavioral;