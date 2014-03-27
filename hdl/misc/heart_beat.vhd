library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity heart_beater is
Generic(	HB_length		   : integer :=5;		--length of the heart beat in pixels	
			HB_width      : integer :=5;		--width of the heart beat in pixels
			alt_aft_frame	: integer  :=3	--alternate color after this many frames (max value 31)
		);  
port
(
	rst    : in std_logic;
	din    : in std_logic_vector(23 downto 0);
	wr_en  : in std_logic;
	pclk_i : in std_logic;
	resX	  : in std_logic_vector(15 downto 0);
	resY	  : in std_logic_vector(15 downto 0);
	dout   : out std_logic_vector(23 downto 0)

);
end heart_beater;

architecture Behavioral of heart_beater is
	signal pixel_cnt        : unsigned(15 downto 0):=(others=>'0');
   signal line_cnt         : unsigned(15 downto 0):=(others=>'0');
	signal frame_cnt			: unsigned(4 downto 0):=(others=>'0');
	signal HB_color			: std_logic_vector(23 downto 0);			--Heart beat color
	signal color	         : std_logic;									-- selects the color
	signal mux1_select	   : std_logic;


begin
	pix_counter:process(rst, pclk_i)							--counts the number of pixel processed
	begin
		if rst='1' then

			pixel_cnt <= (others=>'0');
			line_cnt  <= (others=>'0');
			color     <= '0';
		elsif rising_edge(pclk_i) then

			if wr_en='1' then

				if pixel_cnt>=unsigned(resX)-1 then 				--end of a line
					line_cnt<= line_cnt+1;						--increment lines
					pixel_cnt<=to_unsigned(0,16);

					if line_cnt=unsigned(resY)-1 then			--check for end of frame
						line_cnt  <=(others=>'0');						--start of new frame
						frame_cnt <= frame_cnt+1;
						if frame_cnt=to_unsigned(alt_aft_frame,5)-1 then
							frame_cnt<=(others=>'0');
							color<= not( color);         --alternate color
						end if;
					end if;
					else
               pixel_cnt<=pixel_cnt+1;
				end if;

			end if;
		end if;
	end process;

	selector:process(rst,pixel_cnt,line_cnt)
		begin

			if rst='1' then
				mux1_select<='0';
			elsif pixel_cnt<to_unsigned(HB_length,16) and line_cnt<to_unsigned(HB_width,16) then
				mux1_select<='0';
			else
				mux1_select<='1';
			end if;
		end process;

	mux1:process(rst, mux1_select, din, HB_color)
		begin
			case mux1_select is
				when '0' => dout <= HB_color;
				when '1' => dout<= din;
				when others => dout <= HB_color; 
			end case;
		end process;

	mux2:process(rst,color)
		begin
			case color is
				when '0' => HB_color<=X"FF0000";      --red
				when '1' => HB_color<=X"0000FF";      --blue
				when others=> HB_color<=X"00FF00";
			end case;
		end process;

end Behavioral;
